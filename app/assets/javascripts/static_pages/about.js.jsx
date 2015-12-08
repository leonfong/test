  var CommentBox = React.createClass({
    render: function() {
      return (
        <div className="well">
          Hello, world! I am a CommentBox.dddddd
        </div>
      );
    }
  });

  
  // React.render(
  //   <CommentBox data={data}/>,
  //   document.getElementById('content')
  // );

  var ready = function() {
    //alert("dddd "+ document.getElementById('content'))
    React.render(
      <CommentBox />,
      document.getElementById('content')
    );
  };

  //$(document).on("ready page:load", ready);