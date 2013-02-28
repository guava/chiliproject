require 'uri'

module ChartsHelper

  def bar_chart(data, rows, key)
    labels = retrieve_labels(rows)
    data = convert_data(data, rows, key)

    generate_url(I18n.t("charts.#{key}"), labels, data)
  end

private

  def generate_url(title, labels, data)
    ceiling = data.map { |line| line.max }.max
    parsed_data = data.map { |line| line.join(',') }.join('|')

    width = (40 * 2 + 2 + 15) * labels.size + 25
    width = [width, 175].max

    url = "//chart.googleapis.com/chart?chxl=1:|#{labels.join('|')}"
    url << "&chxr=0,0,#{ceiling}&chxt=y,x"
    url << "&chbh=40,2,15&chs=#{width}x200&cht=bvg&chco=FF0000,00A500"
    url << "&chds=0,#{ceiling},0,#{ceiling}"
    url << "&chd=t:#{parsed_data}"
    url << "&chdl=Open|Closed&chdlp=t&chma=|35,10"
    url << "&chtt=#{title}&chts=676767,14"

    URI.encode(url)
  end

  def retrieve_labels(rows)
    rows.map(&:to_s)
  end

  def convert_data(data, rows, key)
    t = {}
    ids = rows.map(&:id)

    ids.each do |id|
      t[id] = {open: 0, closed: 0}

      data.each do |hash|
        next unless id == hash[key]

        if hash['closed'].zero?
          t[id][:open] += hash['total']
        else
          t[id][:closed] += hash['total']
        end
      end
    end

    [t.map { |k, v| v[:open] }, t.map { |k, v| v[:closed] }]
  end
end
